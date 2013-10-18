require File.join(File.dirname(__FILE__), 'Dash.rb')

$dash = Dash.new({
    :name           => 'Photoshop CS5 JS Tools Guide',
    :docs_root      => 'photoshop-cs5-javascript-tools',
    :icon           => File.join('icon-images', 'adobe_cs5_32x32.png')
})

# used the following command to generate html (adjust for pathing)
# pdf2htmlEX -f 9 -l 294 --printing 0 --zoom 1.6 --outline-filename toc.html --embed cFijo --dest-dir src-docs/photoshop-cs5-javascript-tools src/photoshop_cs5_javascript_tools_guide.pdf

$mainPage = 'photoshop_cs5_javascript_tools_guide.html'
type = 'Guide'

def toc(element, prefix, cnt)
    type = 'Guide'
    ays = element.css('> a')
    uls = element.css('> ul')

    if ays.length == 1
        if prefix.match(/^\s*4$/)
            prefix = "#{prefix}.#{cnt < 10 ? '0' + cnt.to_s : cnt}"
        else
            prefix = "#{prefix}.#{cnt}"
        end
        name = "#{prefix}  #{ays[0].text}"
        path = "#{$mainPage}#{ays[0]['href']}"

        $dash.sql_insert(name, type, path)
        # puts "<a> #{name}"
        cnt = cnt + 1
    end
    if uls.length == 1
        # puts "<ul>"
        newCnt = 1
        uls.css('> li').each do |newli|
            newCnt = toc(newli, "#{prefix}", newCnt)
        end
    end

    return cnt
end





docToc = $dash.get_noko_doc('toc.html')

root = docToc.at_xpath('.//ul')

rootCnt = 1

root.css('> li').each do |li|
    a = li.at_css('> a')
    name = "#{rootCnt < 10 ? ' ' + rootCnt.to_s : rootCnt}  #{a.text}"
    path = "#{$mainPage}#{a['href']}"
    $dash.sql_insert(name, type, path)
    # puts "<a> #{name}"

    ul = li.at_css('> ul')
    if ul
        newCnt = 1
        ul.css('> li').each do |subLi|
            newCnt = toc(subLi, "#{rootCnt < 10 ? ' ' + rootCnt.to_s : rootCnt}", newCnt)
        end
    end

    rootCnt = rootCnt + 1

end



# $dash.sql_execute({
    # :noop => true,
#     :filter => {
#         :limit => 5,
#         :type => 'Section',
#         :name => 'Exception'
#     }
# })
$dash.sql_execute

$dash.copy_docs


puts "\nAll done!"
