require File.join(File.dirname(__FILE__), 'Dash.rb')

dash = Dash.new({
    :name           => 'Java 5',
    :docs_root      => 'java5docs',
    :icon           => File.join('icon-images', 'java_32x32.png')
})

# The Java API is generated with javadoc, so all we need here is to kickoff the
# javadocset binary and make sure the docset is spit out into the correct location.
dash.create_javadocset

puts "\nAll done!"
