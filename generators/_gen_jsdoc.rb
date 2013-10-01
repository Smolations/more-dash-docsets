require File.join(File.dirname(__FILE__), 'Dash.rb')

dash = Dash.new({
    :name           => 'JSDoc',
    :docs_root      => 'usejsdoc.org',
    :icon           => File.join('icon-images', 'js.png')
})


# puts dash.get_clean_docs_entries
docIndex = dash.get_noko_doc('index.html')

# guides
docIndex.css('#Getting_Started + dl dt a').each do |a|
    name = a.text.chomp('.')
    type = 'Guide'
    path = a['href']

    dash.sql_insert(name, type, path)
end


# tags
docIndex.css('#JSDoc3_Tag_Dictionary + dl dt a').each do |a|
    name = a.text
    type = 'Tag'
    path = a['href']

    dash.sql_insert(name, type, path)
end



# dash.sql_execute({
#     :noop => true,
#     :filter => {
#         :limit => 5,
#         :type => 'Guide',
#         :name => 'Exception'
#     }
# })
dash.sql_execute

dash.copy_docs

puts "\nAll Done!"
