require File.join(File.dirname(__FILE__), 'Dash.rb')

dash = Dash.new({
    :name           => 'ATG 10.2',
    :docs_root      => 'atg10.2-apidoc',
    :icon           => File.join('icon-images', 'icon_oracle_cloud_32x32.png')
})

# The ATG 10.2 API is generated with javadoc, so all we need here is to kickoff the
# javadocset binary and make sure the docset is spit out into the correct location.
dash.create_javadocset

puts "\nAll done!"
