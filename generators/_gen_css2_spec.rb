require File.join(File.dirname(__FILE__), 'Dash.rb')

dash = Dash.new({
    :name           => 'CSS 2.1 Spec',
    :display_name   => 'CSS 2.1 Specification',
    :docs_root      => 'css2.1-spec',
    :index_page     => 'cover.html'
    # :icon           => File.join('icon-images', 'yepnope_32x32.png')
})

def escapeQuotes(str)
    return str.gsub('"', "'")
end


# properties
properties = []
type = 'Property'
dash.get_noko_doc('propidx.html').css('tr > td:first-child a').each do |a|
    name = a.at_css('span').text.gsub("'", '')
    path = a['href']
    dash.sql_insert(name, type, path)
    properties.push(name)
end


# sections
type = 'Section'
dash.get_noko_doc('cover.html').css('.toc + .toc .tocxref').each do |a|
    name = escapeQuotes(a.text)
    if /^\d/.match(name)
        if /^\d(\.|\s)/.match(name)
            name = " #{name}"
        end
        path = a['href']
        dash.sql_insert(name, type, path)
    end
end


# from the index
type = 'Define'
dash.get_noko_doc('indexlist.html').css('.index-def').each do |a|
    name = escapeQuotes(a['title'])
    path = a['href']

    # properties are in this index as well, so we filter them out
    if /'[^']+'/.match(name)
        val = Regexp.last_match(0).gsub("'", '')

        if !properties.include?(val)
            # puts '---->' + name
            dash.sql_insert(name, type, path)
        end
    else
        # puts name
        dash.sql_insert(name, type, path)
    end
end



# dash.sql_execute({
    # :noop => true,
#     :filter => {
    #     :limit => 5,
        # :type => 'Section',
    #     :name => 'Exception'
#     }
# })
dash.sql_execute

dash.copy_docs

puts "\nAll done!"
