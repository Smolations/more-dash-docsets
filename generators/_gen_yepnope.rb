require File.join(File.dirname(__FILE__), 'Dash.rb')

dash = Dash.new({
    :name           => 'yepnope',
    :display_name   => 'yepnope.js',
    :docs_root      => 'yepnopejs.com',
    :icon           => File.join('icon-images', 'yepnope_32x32.png')
})


indexPage   = 'index.html'
docIndex    = dash.get_noko_doc(indexPage)

# going to prefix sections/guides with a numbering system
mainCnt     = 0
subCnt      = 1

docIndex.css('article').each do |article|
    h1 = article.at_css('h1')

    # there are no anchors with IDs to naturally link to, even without a TOC, so we'll
    # kill 2 birds with one stone here by doing both.
    if h1
        mainCnt     = mainCnt + 1
        subCnt      = 1
        type        = 'Section'
        h1_anchorid = "anchor-#{mainCnt}"
        name        = "#{mainCnt}. #{h1.text}"
        newanchor   = dash.get_dash_anchor(docIndex, name, type, h1_anchorid)
        h1.before(newanchor)

        # now get values for sql inserts
        path        = "#{indexPage}\##{h1_anchorid}"
        dash.sql_insert(name, type, path)


        type = 'Guide'
        article.css('h3').each do |h3|
            h3_anchorid = "#{h1_anchorid}-#{subCnt}"
            name        = "#{mainCnt}-#{subCnt < 10 ? '0' + subCnt.to_s : subCnt}. #{h3.text}"
            newanchor   = dash.get_dash_anchor(docIndex, name, type, h3_anchorid)
            h3.before(newanchor)

            # now get values for sql inserts
            path        = "#{indexPage}\##{h3_anchorid}"
            dash.sql_insert(name, type, path)

            subCnt = subCnt + 1
        end

    else
        type = 'Guide'
        article.css('h3').each do |h3|
            h3_anchorid = "anchor-#{mainCnt}-#{subCnt}"
            name        = "#{mainCnt}-#{subCnt < 10 ? '0' + subCnt.to_s : subCnt}. #{h3.text}"
            newanchor   = dash.get_dash_anchor(docIndex, name, type, h3_anchorid)
            h3.before(newanchor)

            # now get values for sql inserts
            path        = "#{indexPage}\##{h3_anchorid}"
            dash.sql_insert(name, type, path)

            subCnt = subCnt + 1
        end
    end
end

dash.save_noko_doc(docIndex, indexPage)


# dash.sql_execute({
    # :noop => true,
    # :filter => {
    #     :limit => 5,
    #     :type => 'Guide',
    #     :name => 'Exception'
    # }
# })
dash.sql_execute

dash.copy_docs

puts "\nAll done!"
