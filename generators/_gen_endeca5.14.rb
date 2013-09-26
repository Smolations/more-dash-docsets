require File.join(File.dirname(__FILE__), 'Dash.rb')

dash = Dash.new({
    :name           => 'Endeca-5.14',
    :docs_root      => 'endeca5.14',
    :icon           => File.join('icon-images', 'endeca1.png')
})

# The Endeca API is generated with javadoc, so all we need here is to kickoff the
# javadocset binary and make sure the docset is spit out into the correct location.
dash.create_javadocset
