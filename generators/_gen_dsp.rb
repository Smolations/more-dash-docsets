require File.join(File.dirname(__FILE__), 'Dash.rb')

dash = Dash.new({
    :name           => 'DSP',
    :docs_root      => 'dsptags',
    :icon           => File.join('icon-images', 'icon_oracle.png')
})


entries = dash.get_clean_docs_entries
entries.shift

cnt  = 0
entries.each do |entry|
    name = /^s\d+dsp([a-z]+)01\.html$/.match(entry)[1]
    type = 'Tag'
    path = entry
    dash.sql_insert(name, type, path)
    cnt = cnt + 1
end

puts "\nProcessed a total of #{cnt} files."

# dash.sql_execute({
#     :noop => true,
#     :filter => {
#         :limit => 5,
#         :type => 'Guide',
#         :name => 'Exception'
#     }
# })
dash.sql_execute

dash.copy_docs()

puts "\nDone."
