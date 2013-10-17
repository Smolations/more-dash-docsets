require File.join(File.dirname(__FILE__), 'Dash.rb')

dash = Dash.new({
    :name           => 'Photoshop CS5 JS Reference',
    :docs_root      => 'photoshop-cs5-javascript-ref',
    :icon           => File.join('icon-images', 'adobe_cs5_32x32.png')
})

# used the following command to generate html (adjust for pathing)
# pdf2htmlEX -f 37 -l 225 --printing 0 --zoom 1.6 --outline-filename toc.html --embed cFijo --dest-dir html photoshop_cs5_javascript_ref.pdf


mainPage = 'photoshop_cs5_javascript_ref.html'

docToc = dash.get_noko_doc('toc.html')

docToc.css('[href*=pf25]').each do |obj|
    # only want to grab object reference here
    if obj.text.match('Object Reference')
        ul = obj.next_element

        ul.css('> li + li').each do |li|
            objectAnchor = li.first_element_child
            name = objectAnchor.text
            type = 'Object'
            path = "#{mainPage}#{objectAnchor['href']}"
            dash.sql_insert(name, type, path)

            # puts "object: #{name}"

            # properties/methods
            # not sure if this can be done well with the given output from pdf2htmlEX
            li.css('> ul > li').each do |li2|
                label = li2.first_element_child.text
                type = 'Property'
                if label.match('eth')
                    type = 'Method'
                end

                li2.css('ul a').each do |a|
                    name = a.text
                    path = "#{mainPage}#{a['href']}"
                    dash.sql_insert(name, type, path)
                end
            end

            # break
        end
    end
end

# add the Event ID Codes appendix
name = 'Appendix A: Event ID Codes'
type = 'Section'
path = "#{mainPage}\#pfda"
dash.sql_insert(name, type, path)


# dash.sql_execute({
#     :noop => true,
#     :filter => {
#         :limit => 5,
#         :type => 'Section',
#         :name => 'Exception'
#     }
# })
dash.sql_execute

dash.copy_docs


puts "\nAll done!"
