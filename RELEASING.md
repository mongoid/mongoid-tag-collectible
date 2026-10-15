# Releasing Mongoid Tag Collectible

## Prepare

Use the upstream checkout on a clean `master`, verify `origin` points to `mongoid/mongoid-tag-collectible`, and run `git pull --ff-only`. Check supported combinations in [GitHub Actions](https://github.com/mongoid/mongoid-tag-collectible/actions). Use patch versions for fixes, minor versions for backward-compatible features, and major versions for breaking changes.

Update `lib/mongoid-tag-collectible/version.rb`. Date the matching changelog section using `YYYY/MM/DD` and remove its contribution placeholder.

```sh
bundle install
bundle exec rake
git add CHANGELOG.md lib/mongoid-tag-collectible/version.rb RELEASING.md
git commit -m "Preparing for release, 0.2.3."
git push origin master
```

Wait for the preparation commit's CI checks to pass.

## Publish RubyGems and GitHub

```sh
bundle exec rake release
```

The task builds the package, pushes its tag, and publishes to RubyGems. Complete MFA when prompted. If interrupted, inspect the existing tag and RubyGems version before retrying; never move a published tag. If only publication is missing, resume with `gem push pkg/mongoid-tag-collectible-0.2.3.gem`.

A Git tag is not a GitHub release. Once RubyGems publication is verified, publish a matching GitHub release with changelog notes:

```sh
version=0.2.3
notes="$(mktemp)"
awk -v version="$version" '
  /^### / {
    if (found) exit
    if ($2 == version) found = 1
    next
  }
  found { print }
' CHANGELOG.md > "$notes"
gh release create "v$version" --repo mongoid/mongoid-tag-collectible --verify-tag --title "$version" --notes-file "$notes" --latest
rm "$notes"
curl --fail --silent --show-error "https://rubygems.org/api/v2/rubygems/mongoid-tag-collectible/versions/$version.json"
gh release view "v$version" --repo mongoid/mongoid-tag-collectible
```

Verify both the published gem and non-draft GitHub release before declaring completion.

## Prepare the Next Version

Increment the development patch version in `lib/mongoid-tag-collectible/version.rb` (for example, `0.2.4`). Add `### 0.2.4 (Next)` with a contribution placeholder above the released changelog section. Commit and push to `master`, leaving the released tag unchanged.
