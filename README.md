# move_file_on_upload
Moves files that aren't in the top level of a bucket on a put object event.

# Requirements
* Ruby 2.7.0 (for supported AWS Lambda runtime)

# Packaging
Be sure you are vendoring gems with
`bundle config set --local deployment 'true'`

For now, manual zip:
`zip ../move_file_on_upload.zip **`
