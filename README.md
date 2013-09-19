more-dash-docsets
=================

Greetings. I found myself excited about Dash and the prospect of creating my own docsets, so I set out to create a loose framework to do just that. I didn't build it for anyone but myself, but if you'd like to use it, feel free. In case I forget, and I guess for anyone interested, I shall spend some time explaining how I've gone about creating my docsets. For this project, I chose Ruby (1.8.7).

I suppose the NEXT best place to start is to outline the requirements for using the Dash class:

* Ruby 1.8+
* [Nokogiri 1.5.10](http://nokogiri.org/) - I am running OS X 10.8 which is bundled with Ruby 1.8.7. I choose not to manage multiple Ruby versions on my machine. As a result, 1.5.10 is the version of Nokogiri I had to install. Version 1.6+ requires Ruby 1.9+, so it was not an option. These scripts should definitely work with the newer versions of both software, however.
* Git
* [ruby-git](https://github.com/schacon/ruby-git) - A Ruby implementation for Git


I suppose the NEXT best place to start is the file structure:

    more-dash-docsets
        `- bin
        `- docs
        `- docsets
        `- generators
        `- icon-images
        `- resources
        `- src
        `- src-docs

**bin** - This is just a folder for the `javadocset` binary that the Dash team already provides. I hope they don't mind.

**docs** - This is the RDoc-generated documentation for the Dash class.

**docsets** - This is where each docset is created. I add them to Dash directly from this folder. The benefit here is that Dash seems to hold a reference to each docset in near-real-time, so as new docsets overwrite old ones, Dash updates automatically.

**generators** - The home of the Dash class and each generation script.

**icon-images** - A folder where I keep 32x32 as well as source images to be used as (or used for generating) icons in the docsets.

**resources** - Project templates and other random resources that are used to generate the docsets. The most notable of which is the Info.plist template which is required for all docsets.

**src** - This folder is hidden and isn't referenced in any generator. It is only a place where compressed files of the src-docs live. I only mention it because it exists in the .gitignore file.

**src-docs** - Each project has source documentation in the form of a single folder containing a collection of HTML, CSS, Javascript, and images. When you specify a docs_root in each generator script, that path is relative to this directory.

------------------------------------------------------------------------------------

PuppetDocs - A Practical Example
--------------------------------

The easiest way to explain the framework is to run through an example.

### Go Get The Docs

The first thing to do is to acquire the HTML documentation. If you are lucky, the documentation you seek will be available as a standalone, compressed file filled with structured HTML. If you are unlucky, you will have to use `wget` to crawl a URL and download everything it finds. The obvious drawback to the `wget` method is getting a whole bunch of stuff you don't need. Also, since it follows links it finds in pages when downloading files, you are never sure if you have gotten every file you need for complete documentation.

In case you have to resort to using `wget` to retrieve your documentation, here is the command I have been using:

    wget -nv -e robots=off -o wget.nv.log -r -nc -p http://docs.domain.com/latest

| Option          | Description
| --------------- | -----------
| `-nv`           | No verbose. This makes the output a bit cleaner. You will be downloading quite a few files after all.
| `-e robots=off` | Execute command. Commands are whatever you can put in `~/.wgetrc`. In this case, we are ignoring the robots.txt file.
| `-o`            | Output file. Duh. ;]
| `-r`            | Recursive. Gotta make sure you can move through the directory hierarchy.
| `-nc`           | No-clobber. If the file has already been downloaded, don't download it again. This is important because usually every HTML file references the same CSS, Javascript, and even some images. You definitely don't want to waste time downloading the same resources over and over. This is also useful in case your download is halted for some reason and you want to start it back up again.
| `-p`            | Page requisites. Tell wget to download stylesheets, scripts, images, and anything else necessary to display the page correctly offline.

Once you have the documentation, you will need to copy it into the `src-docs` folder. Let's use Puppet as an example. The docs for Puppet were available as a standalone, compressed file (hooray!). It's basically the entire docs.puppetlabs.com site. I copied the documentation folder into `more-dash-docsets/src-docs/puppetdocs-latest`. The `puppetdocs-latest` folder contains the index.html that is the starting point for all docs, and each module in it's own folder. I chose to take the time at this point to go find a suitable icon (and resize it to 32x32) for the docset as well. Our folder hierarchy (only relavant files shown) now looks like this:

    more-dash-docsets/
        `- docsets/
        `- generators/
        `- icon-images/
            `- puppetlabs.png
        `- resources/
            `- Info.plist
        `- src-docs/
            `- puppetdocs-latest/


### Spin Up A Generator

The next step is to create the generator script. The naming convention has no significance here.

    more-dash-docsets/
        `- docsets/
        `- generators/
            `- _gen_puppet.rb
        `- icon-images/
            `- puppetlabs.png
        `- resources/
            `- Info.plist
        `- src-docs/
            `- puppetdocs-latest/

The first thing to do in a generator file is to import the Dash helper class and instantiate a Dash object with a few required parameters.

```ruby
require File.join(File.dirname(__FILE__), 'Dash.rb')

dash = Dash.new({
    :name           => 'Puppet',
    :display_name   => 'Puppet 3.2',
    :docs_root      => 'puppetdocs-latest',
    :icon           => File.join('icon-images', 'puppetlabs.png')
})
```

Since specifying relative paths makes the script fairly brittle depending on what directory you run the generator from, I chose to go with a more explicit way of importing the Dash class, which happens to be in the same directory.

The dash constructor takes 2 required parameters and allows for two optional parameters:

| Key             | Required? | Description
|-----------------|:---------:|------------
| `:name`         |    Yes    | This becomes the file name of the docset (e.g. `Puppet.docset`).
| `:docs_root`    |    Yes    | This is the name of the folder that is dropped into the `src-docs` directory. It is the _documentation root_. This value can be accessed later in the script, as an absolute path, with `dash::docs_root` (notice that it's an attribute on the instance, not the class).
| `:display_name` |    No     | What Dash will display in it's sidebar. If this parameter is omitted, it defaults to the value for `:name`.
| `:icon`         |    No     | A path to a 32x32 image which will be renamed and copied into the docset. The path can be relative to the `more-dash-docsets/` root or an absolute path.

As soon as a Dash object is created, many magical things happen:

1. A handful of paths are set so the Dash class knows where to find and put things.
2. If a docset with the same name exists, a backup file (ignored by Git) is created with a .bak extension.
3. The entire docset hierarchy is created.
4. The icon image (`icon.png`) is placed in the correct location if a path was specified in the constructor.
5. The `Info.plist` file is created, inserting the correct values in the correct places.
6. The sqlite3 database is created in the correct location.
7. A repo is created or reset in the `docs_root` directory.

#### A word about the docs repo...

As I wrote each generator script, I found that there was quite a bit of trial and error. I also found that I would insert redundant elements if I ran my scripts repeatedly. It is also important to me that I retain an original copy of the documentation so that I could start over whenever I needed to. When the Dash constructor reaches the Git repository code, it ensures that:

1. A repo is created. If one isn't already, it is created for you and an initial import of all the docs is completed.
2. A "dev" branch exists. The master branch is intended to reference the original, pristine documentation. The dev branch is where all of the generator script changes take place.
3. The current HEAD points to a _clean_ dev branch. A `git reset --hard HEAD` is run to ensure a clean working tree.

It should be clear that each time the script is run, the previous changes made by the script are erased. That's OK! Borrowing a strategy from Puppet, this entire framework was created so that the changes made by the generator are _idempotent_. You should expect the same results each time you run the generator (unless you made changes to the generator of course). This is why the entire docset hierarchy, along with the sqlite database, is re-created on each run of the generator.


### What's So Special about YOUR Docs?

Every generator has the class require statement and needs a Dash object to be created. Once that is out of the way, you will need to analyze the structure of the documentation to determine what processing is required for the Dash entries you want. Do you want Dash to know about Guides? Do you want to document options as well as the commands they are associated with? All of that, and more, is up to you. Let's continue with the Puppet use case.


#### Trim the fat

Many of the documentation folders in the puppetdocs include documentation for earlier versions of the software. Since I only needed the latest documentation for the Puppet docset, it made sense to remove these folders before doing any processing. Since there is no reason for the older docs to ever be parsed, there is no reason for them to exist in this project. Remember that the master branch contains the original documentation. My first step was to make sure I was on the dev branch before going through and deleting all of these extraneous directories. I then **committed** these changes to the dev branch. This cleaner state acts as a starting point for documentation, and ensures that I won't need to worry about those extra files during multiple generator runs in the future.


#### Making src and href paths relative

It turns out that the puppetdocs are intended to be run by a web server. All of the paths to resources and pages are relative to the site root, so they begin with a forward slash. This is a problem for Dash as it does not use a web server to serve up its documentation (I think at least). Therefore, our first task will be to change all of the paths so that they are relative to the documentation root. If your docs paths are already relative, then you've won half the battle already!

Perhaps in future versions of this class I will integrate this process into the class definition itself, so that it can be executed with a single command. Since I only needed this functionality for 2 docsets I have generated (Puppet and Vagrant), I simply copied and pasted the code I needed. That code is a collection of functions and global variables:

```ruby
# so dive can get at it recursively..
$dash = dash

# this is how we'll keep track of how deep in the directory structure we are as we make paths
# relative. this array is joined with the system file separator and prepended to absolute paths.
$levels = [ '.' ]

# shortcut methods to increase/decrease levels.
def level_up
    $levels.push('/..')
end
def level_down
    $levels.pop
end

$fileCount = 0
def dive(path)
    # add any file/folder names which you know do not contain any pathing that concerns you.
    # this isn't required, but it will make processing go just a bit faster.
    entries = $dash.clean_dir_entries(path, [
        'config.ru', 'favicon.ico', 'module_cheat_sheet.pdf', 'puppet_core_types_cheatsheet.pdf',
        'README.txt', 'sitemap.xml', 'images', 'latest', 'images', 'assets', 'fonts'
    ])

    entries.each do |entry|
        entry_path = File.join(path, entry)

        # if we're looking at a directory and not a file [to parse], increase the directory
        # depth, pass the path to this function, then decrease the level back to where it was.
        if File.directory?(entry_path)
            level_up
            dive(entry_path)
            level_down

        # now that we know it's a file, let's get into it.
        elsif !entry.match(/\.html$/).nil?
            $fileCount = $fileCount + 1
            doc = $dash.get_noko_doc(entry_path)
            doc.css('[href]').each {|element| element['href'].match(/^\//) && element['href'] = $levels.join + element['href'] }
            doc.css('[src]').each {|element| element['src'].match(/^\//) && element['src'] = $levels.join + element['src'] }
            $dash.save_noko_doc(doc, entry_path)

            # remove google analytics and tracking
            `sed -i '' -e '/<!-- Google analytics -->/,/<!-- End Google analytics -->/d' #{entry_path}`
            `sed -i '' -e '/<!-- BEGIN: MARKETO TRACKING -->/,/<!-- END: MARKETO TRACKING -->/d' #{entry_path}`
        end
    end
end

# kick off the function to make href and src paths relative
puts "Relative-izing src/href attributes and removing analytics..."
dive(dash::docs_root)
puts " \`-Done processing #{$fileCount} files."
```

I hope that the comments make most of the processing clear. I want to discuss just a couple of things that might _not_ be so clear.

The `$fileCount` variable is included only so I get a little bit of information in stdout. You will see much of this in the generators. There is _some_ automatic output from the Dash object, but statistics for document processing differ from project to project, so the onus is on the author to get acquire that feedback.

You'll notice that I use Nokogiri to replace all of the src and href attributes with relative URLs which utilize `$levels`. However, each doc also had scripts for Google Analytics as well as MARKETO TRACKING (whatever that is). Luckily for me, each of these blocks was surrounded by comments to identify them. I chose to go with `sed` to replace the markup in-place because it was the easiest to use. This method demonstrates that you can utilize any command-line tool that makes your task(s) easier.


#### Creating Guides entries

Puppetdocs include not only a reference to the syntax and command-line tools, but also a collection of Guides. This was easy enough to find since there's a folder in the docs root named `guides`. So how do we process them? Well, an ideal situation is that a link to each one of them is in a list on some HTML page. We could then just loop through that list, grab the title and file path from the anchor (<a></a>) element, and insert the entries into the database. Unfortunately, there is no page that I found quickly that has that list. I got a bit creative.

Within the `guides` folder, each guide appeared to have it's own page. I opened up a few of the files in a text editor and saw a pattern with the <title></title> elements:

    <title>Getting Started With Cloud Provisioner — Documentation — Puppet Labs</title>

Each title element had the name of the guide followed by the same " — Documentation — Puppet Labs" suffix. My solution here was to loop through each file and parse the title to get what I needed. It's important to note at this point that you need three values for every Dash entry: `name`, `type`, and `path`. The `path` value should always be relative to the documentation root:

```ruby
# load up guides
puts "Processing guides..."
guides_path = File.join(dash::docs_root, 'guides')
guides      = dash.clean_dir_entries(guides_path)
cnt         = 0

guides.each do |entry|
    entry_path  = File.join(guides_path, entry)
    sql_path    = File.join('guides', entry)

    if !File.directory?(entry_path)
        doc     = $dash.get_noko_doc(sql_path)
        # the split character had to be copied and pasted from one of the docs. it is &#8212;
        name    = doc.at_css('title').content.split('—').shift.strip
        type    = 'Guide'
        if !name.nil?
            cnt = cnt + 1
            $dash.sql_insert(name, type, sql_path)
        end
    end
end
puts " \`- Done processing #{cnt} files."
```

You can see that the first thing I do is to get an array of all the files in the `guides` directory. Keep in mind that the `Dash::clean_dir_entries` only returns entries in the path that is passed to it. It is not recursive. This method basically gets all entries in the path and then takes out entries that would be problematic when processing (e.g. '.', '..', '.git'). I then loop through the entries, ensure that I'm looking at a file and not a directory, and then use Nokogiri to get the value I need to parse. Once we have the name from the title element, 'Guide' is the `type` and the `path` is constructed from each entry file name. It should also be clear that I only insert a database entry if the file being parsed returns a name.

The final step is to tell the Dash object to insert the sql entries. It doesn't actually insert them at this time, it only creates the query and stores it. More on this later.


#### Generating Types entries

Puppet syntax uses defined types for resources. These are used so often in Puppet scripts that it makes having them in Dash a necessity. All of the docs which are versioned also include a symlink named `latest` that points to the latest documentation. This made it easy to set a variable for a common version that other processing code blocks can use.

Fortunately, every type is listed in `references/latest/type.html` using an unordered list of anchors. That's all that is needed to insert the necessary queries for Dash to be aware of each type:

```ruby
# the following pages are all versioned. we sync versions here.
refs_version    = 'latest'
# refs_version = '3.2.3'    # if a specific version is desired

# Types
puts "Processing types reference..."
cnt         = 0
refs_page   = 'type.html'
sql_path    = File.join('references', refs_version, refs_page)

docRef      = dash.get_noko_doc(sql_path)
# e.g. <li class="toc-lv2"><a href="#type">
docRef.css('.toc-lv3 a').each do |a|
    cnt     = cnt + 1
    path    = sql_path + a['href']
    name    = path.split('#').pop
    type    = 'Type'
    dash.sql_insert(name, type, path)
end
puts " \`- Done processing #{cnt} Type anchors."
```

There is similar processing for functions, metaparameters, and Facter facts, so I'm omitting those code blocks. If you are curious, you can peruse the Puppet generator (`generators/_gen_puppet.rb`).


#### Puppet binary commands

Puppet also has command line tools. This structure was slightly different, but didn't require me to inspect the content of any pages! Each command had it's own HTML page, in the format _command_.html. Since I can get the name AND path simply from the directory entries, it made the process quite simple:

```ruby
# Commands with the `puppet` binary
puts "Processing \`puppet\` binary commands..."
cnt     = 0
entries = dash.clean_dir_entries( File.join(dash::docs_root, 'man') )

# each command has its own html page. notice that this collection of commands
# is simple enough to only use one Dash feature.
entries.each do |entry|
    cnt = cnt + 1
    name = entry.split('.').shift
    type = 'Command'
    path = File.join('man', entry)
    $dash.sql_insert(name, type, path)
end
puts " \`- Done processing #{cnt} Commands."
```

#### Concluding the script

There are two things you'll want to do at the end of each script:

1. Inspect and/or execute the SQL queries that have been stored during processing
2. Copy the documentation into the docset structure so Dash can actually display the pages referenced by each entry's `path` value in the database

I wanted to be able to inspect queries in a fairly flexible way, so I implemented a method which allows for the queries to be inspected without being executed (`:noop => true`). In addition, it is possible to filter the inspection by the number of desired results to display (`:limit`), any part of the name (`:name`), and by entry type (`:type). I always keep a commented out version of these options to remind myself of the filters, and because I ALWAYS inspect the queries before wasting processing time/power to execute them.

```ruby
# dash.sql_execute({
#     :noop => true,
#     :filter => {
#         :limit => 5,
#         :type => 'Class',
#         :name => 'Exception'
#     }
# })
dash.sql_execute
```

Once I'm satisfied with the SQL and the state of the documents after processing, I then copy the docs:

```ruby
# dash.copy_docs(:noop => true)
dash.copy_docs()

puts "\nDone."
```

I ran the generator after each code block was written, and tested the docset in Dash each time. This is where the idempotence shines. I didn't have to worry about the docs getting cluttered because any changes from the last generation were wiped out with the current one. I didn't need to worry about errant sqlite records for the same reason. Wonderful!


### The Dash TOC

There is no current documentation on the Dash website which tells users how to create a table of contents for entries. I resorted to contacting Dash to ask for some direction on how to do so. The table of contents allows for the functions/methods/properties/etc. to show up in the left pane, in the bottom partition. This gives a bird's eye view to all of the connected pieces of a given entry (e.g. a Class). This TOC is produced for most of the documentation that comes with Dash.

All that is required for this to occur are two things:

1. Create a key/value pair in the `Info.plist` file. This is included in the .plist template that the Dash class uses, so that part is taken care of automatically.

    <key>DashDocSetFamily</key>
    <string>dashtoc</string>

2. Insert a special Dash anchor that allows Dash to "see" what you want in the TOC, and doubles as the location that Dash shows when you click an entry in the TOC.

    <a class="dashAnchor" name="//apple_ref/cpp/ENTRY_TYPE/ENTRY_NAME"></a>

These dash anchors are generally inserted nearby an element which has an id attribute value which is included in the `path` field in the sqlite database (e.g. `reference/functions.html#ENTRY_ID). This allows Dash to scroll to a specific area on the page to display the entry. If no element nearby has a suitable id, then one can be added the the Dash anchor. This anchor is created with the `Dash::get_dash_anchor` method.

Take, for example, this excerpt from the AWS CLI generator:

```ruby
# full relative path from docs_root: cli/latest/reference/
awsCmdFilePath = File.join('reference', 'index.html')
docAwsCmd = dash.get_noko_doc(awsCmdFilePath)

docAwsCmd.css('#options span.pre').each do |span|
    option      = span.content
    newanchorid = option[/\-\-(.*)/, 1]
    newanchor   = dash.get_dash_anchor(docAwsCmd, option, 'Option', newanchorid)
    span.before(newanchor)

    dash.sql_insert( option, 'Option', [awsCmdFilePath, newanchorid].join('#') )
end

# rewrite the file, free up the memory
dash.save_noko_doc(docAwsCmd, awsCmdFilePath)
```

This "command file" contains a list of links to each CLI command. In addition, this index.html page is also the complete documentation for the `aws` command, which includes the command-line options that can be passed to it. It turns out that these options sections are not wrapped with any elements which have id attributes. That means that Dash would be unable to automatically scroll to each option when selected in Dash's side panel. Therefore, I had to add an id attribute to eash _Dash anchor_. I based it off of the option name, stripping the leading "--". You can see that I made sure to use that same `newanchorid` as the hash on the end of the `path` value when inserting the entry into the database.

When inserting Dash anchors, you must be sure to overwrite the contents of the document. Nokogiri allows you to manipulate the DOM structure of the document at will, but changes are not automatically saved into the opened file. That's why `dash.save_noko_doc` is run at the conclusion of the loop.


Resources
---------

* [kapeli.com - Generating Dash Docsets](http://kapeli.com/docsets) The offical Dash documentation for creating docsets. This documentation gives all of the basic information needed to create your own docsets.
