require File.join(File.dirname(__FILE__), 'Dash.rb')

dash = Dash.new({
    :name           => 'ATG 2007.1',
    :docs_root      => 'atg7.1-apidoc',
    :icon           => File.join('icon-images', 'icon_oracle.png')
})

# The ATG 10.2 API is generated with javadoc, so all we need here is to kickoff the
# javadocset binary and make sure the docset is spit out into the correct location.
dash.create_javadocset

puts "\nAll done!"
