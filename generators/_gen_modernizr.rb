require File.join(File.dirname(__FILE__), 'Dash.rb')

# had to use wget to get resources. then renamed docs to index.html. docs transferred
# to src-docs were just the favicon.ico, index.html, and the i/ directory which contains
# all of the media for the page. i also removed the ?v=1 from the css filename. chrome
# wasnt liking this during testing so it wouldnt load the css.


dash = Dash.new({
    :name           => 'Modernizr',
    :docs_root      => 'modernizr',
    :icon           => File.join('icon-images', 'modernizr_32x32.png')
})


# lucky for us, all of the documentation is on a single page
docsPage = 'index.html'
docHtml  = dash.get_noko_doc(docsPage)


# first, going to remove this cloudfront beacon thing
docHtml.at_css('head > script:first-of-type').remove


# second, going to remove the ?v=1 from the css link element
css = docHtml.at_css('head > link[rel=stylesheet]')
css['href'] = css['href'].chomp('?v=1')


# next thing to do it make all of the references to resources relative
docHtml.css('[href], [src]').each do |elem|
    key = 'src'
    if elem.key?('href')
        key = 'href'
    end

    value = elem[key]
    if value.match(/^\/(?=\w)/)
        # puts value
        value[0] = ''
        elem[key] = value
    end
end


# time to comb through the TOC and grab sections. unfortunately, the numbering is done
# using css, so we'll need to manually create it for db entries.
sectionNum = 1
docHtml.css('#toc > ol > li > a').each do |a1|
    name = "#{sectionNum}. #{a1.text}"
    type = 'Section'
    path = docsPage + a1['href']

    dash.sql_insert(name, type, path)

    # get subsections
    subSectionNum = 1
    a1.parent.css('li a').each do |a2|
        name = "#{sectionNum}.#{subSectionNum}. #{a2.text}"
        path = docsPage + a2['href']

        dash.sql_insert(name, type, path)

        subSectionNum = subSectionNum + 1
    end

    sectionNum = sectionNum + 1
end


# save the doc changes
dash.save_noko_doc(docHtml, docsPage)

# dash.sql_execute({
    # :noop => true,
    # :filter => {
    #     # :limit => 5,
    #     :type => 'Command',
    #     # :name => '36'
    # }
# })
dash.sql_execute

# dash.copy_docs(:noop => true)
dash.copy_docs

puts "\nDone."
