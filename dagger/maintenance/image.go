package main

import (
	"bytes"
	"cmp"
	"context"
	"fmt"
	"regexp"
	"slices"
	"strconv"
	"strings"

	"dagger/maintenance/internal/dagger"

	"github.com/google/go-containerregistry/pkg/authn"
	"github.com/google/go-containerregistry/pkg/crane"
	"github.com/google/go-containerregistry/pkg/name"
	containerregistryv1 "github.com/google/go-containerregistry/pkg/v1"
	"github.com/google/go-containerregistry/pkg/v1/remote"
	ocispecv1 "github.com/opencontainers/image-spec/specs-go/v1"
)

const (
	DefaultPgMajor      = 18
	DefaultDistribution = "trixie"
	ExtensionsRegistry  = "ghcr.io/solanicaio"
)

const (
	AnnotationImageSQLVersion  = "io.cloudnativepg.image.sql.version"
	AnnotationImageBaseName    = "io.cloudnativepg.image.base.name"
	AnnotationImageBasePgMajor = "io.cloudnativepg.image.base.pgmajor"
	AnnotationImageBaseOS      = "io.cloudnativepg.image.base.os"
)

var SupportedDistributions = []string{
	"bookworm",
	"trixie",
}

// getImageAnnotations returns the OCI annotations given an image ref.
// If username and password are provided, they will be used for registry authentication.
func getImageAnnotations(ctx context.Context, imageRef string, username string, password *dagger.Secret) (map[string]string, error) {
	// Setting Insecure option to allow fetching images from local registries with no TLS
	ref, err := name.ParseReference(imageRef, name.Insecure)
	if err != nil {
		return nil, err
	}

	var opts []remote.Option
	if password != nil && username != "" {
		plainPassword, err := password.Plaintext(ctx)
		if err != nil {
			return nil, fmt.Errorf("failed to read registry password: %w", err)
		}

		if plainPassword != "" {
			auth := authn.FromConfig(authn.AuthConfig{
				Username: username,
				Password: plainPassword,
			})
			opts = append(opts, remote.WithAuth(auth))
		}
	}

	head, err := remote.Get(ref, opts...)
	if err != nil {
		return nil, err
	}

	switch head.MediaType {
	case ocispecv1.MediaTypeImageIndex:
		indexManifest, err := containerregistryv1.ParseIndexManifest(bytes.NewReader(head.Manifest))
		if err != nil {
			return nil, err
		}
		return indexManifest.Annotations, nil
	case ocispecv1.MediaTypeImageManifest:
		manifest, err := containerregistryv1.ParseManifest(bytes.NewReader(head.Manifest))
		if err != nil {
			return nil, err
		}
		return manifest.Annotations, nil
	}

	return nil, fmt.Errorf("unsupported media type: %s", head.MediaType)
}

// parseImageCoordinates extracts the distribution and PostgreSQL major version
// from the extension image annotations. Every image carries them, and they are
// used to resolve the images of any required extensions for the same
// distribution and major.
func parseImageCoordinates(annotations map[string]string) (string, int, error) {
	distribution := annotations[AnnotationImageBaseOS]
	if distribution == "" {
		return "", 0, fmt.Errorf("missing or empty %q annotation", AnnotationImageBaseOS)
	}

	rawPgMajor := annotations[AnnotationImageBasePgMajor]
	pgMajor, err := strconv.Atoi(rawPgMajor)
	if err != nil {
		return "", 0, fmt.Errorf("invalid %q annotation %q: %w",
			AnnotationImageBasePgMajor, rawPgMajor, err)
	}

	return distribution, pgMajor, nil
}

// getDefaultExtensionImage returns the default extension image for a given extension,
// resolved from the metadata.
func getDefaultExtensionImage(metadata *extensionMetadata) (string, error) {
	return getExtensionImage(metadata, DefaultDistribution, DefaultPgMajor)
}

// getExtensionImage returns the extension image for a given distribution and pgMajor.
func getExtensionImage(metadata *extensionMetadata, distribution string, pgMajor int) (string, error) {
	version, buildVersion, err := extractExtensionVersion(metadata.Versions, distribution, pgMajor)
	if err != nil {
		return "", fmt.Errorf("while extracting extension version for %s: %w", metadata.Name, err)
	}

	image := fmt.Sprintf("%s/%s:%s-%s-%s",
		ExtensionsRegistry, metadata.ImageName, version, buildVersion, distribution)

	return image, nil
}

// getExtensionImageWithTimestamp returns the extension image with the latest timestamp
// for a given distribution and pgMajor.
func getExtensionImageWithTimestamp(metadata *extensionMetadata, distribution string, pgMajor int) (string, error) {
	imageName := fmt.Sprintf("%s/%s", ExtensionsRegistry, metadata.ImageName)
	tags, err := crane.ListTags(imageName)
	if err != nil {
		return "", fmt.Errorf("while listing tags for image %s: %w", imageName, err)
	}

	version, buildVersion, err := extractExtensionVersion(metadata.Versions, distribution, pgMajor)
	if err != nil {
		return "", fmt.Errorf("while extracting extension version for %s: %w", metadata.Name, err)
	}

	re := regexp.MustCompile(
		fmt.Sprintf(`^%s-(\d{12})-%s-%s$`,
			regexp.QuoteMeta(version),
			buildVersion,
			distribution,
		),
	)

	var latestTag string
	for _, tag := range tags {
		if re.MatchString(tag) && tag > latestTag {
			latestTag = tag
		}
	}
	if latestTag == "" {
		return "", fmt.Errorf(
			"no image found for image %s (version=%s pgMajor=%d os=%s)",
			imageName, version, pgMajor, distribution,
		)
	}

	imageRef := fmt.Sprintf("%s:%s", imageName, latestTag)

	ref, err := name.ParseReference(imageRef, name.Insecure)
	if err != nil {
		return "", fmt.Errorf("while parsing image reference %s: %w", imageRef, err)
	}

	desc, err := remote.Get(ref)
	if err != nil {
		return "", fmt.Errorf("while fetching digest for image %s: %w", imageRef, err)
	}

	return fmt.Sprintf("%s@%s", imageRef, desc.Digest.String()), nil
}

// extractExtensionVersion returns the extension version for a given distribution and pgMajor,
// extracted from the extension's metadata.
func extractExtensionVersion(versions versionMap, distribution string, pgMajor int) (string, string, error) {
	major := strconv.Itoa(pgMajor)
	extVersion, ok := versions[distribution][major]
	if !ok {
		var buildVersions []string
		for buildVersion := range versions[distribution] {
			if strings.HasPrefix(buildVersion, major+".") {
				buildVersions = append(buildVersions, buildVersion)
			}
		}
		slices.SortFunc(buildVersions, compareDottedVersions)
		if len(buildVersions) == 0 {
			return "", "", fmt.Errorf("no package version found for distribution %q and version %d",
				distribution, pgMajor)
		}

		major = buildVersions[len(buildVersions)-1]
		extVersion = versions[distribution][major]
	}

	// Keep this in sync with getExtensionVersion in docker-bake.hcl.
	re := regexp.MustCompile(`^(\d+(?::\d+)?(?:\.\d+)*)`)
	matches := re.FindStringSubmatch(extVersion.Package)
	if len(matches) < 2 {
		return "", "", fmt.Errorf("cannot extract extension version from %q", extVersion.Package)
	}

	return strings.ReplaceAll(matches[1], ":", "-"), major, nil
}

func compareDottedVersions(a, b string) int {
	left, right := strings.Split(a, "."), strings.Split(b, ".")
	for i := 0; i < max(len(left), len(right)); i++ {
		var l, r int
		if i < len(left) {
			l, _ = strconv.Atoi(left[i])
		}
		if i < len(right) {
			r, _ = strconv.Atoi(right[i])
		}
		if result := cmp.Compare(l, r); result != 0 {
			return result
		}
	}
	return 0
}
