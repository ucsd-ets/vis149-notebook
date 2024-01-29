# VIS 149 Jupyter notebook

## Automated Builds

A new version of the image is built whenever the repository is updated. The tag of the build is the same as the branch. 

## How to create a release

First, determine on the tag to use. It's recommended to use the current quarter. The tag would be "sp23" for spring 2023.

Open the [Releases](../../releases) page and click the `Create a new release` button. Enter the tag in the "Choose a Tag" field and press enter to confirm. Then click "Publish Release" to create the tag.

You can also create a release using the git CLI.

    git tag sp23
    git push origin sp23

## How to re-release

Re-releasing is the same as making a release, except that we need to delete the existing release.

Open the [Releases](../../releases) page, click the Releases tab, and delete the release.

Open the [Releases](../../releases) page, click the Tags tab, and delete the tag.

And for CLI users

    git -d sp23
    git push ---delete origin sp23

Now that the tag and release are gone, follow the "How to create a release" instructions.
