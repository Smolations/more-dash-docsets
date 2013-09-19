more-dash-docsets
=================

Greetings. I found myself excited about Dash and the prospect of creating my own docsets, so I set out to create a loose framework to do just that. I didn't build it for anyone but myself, but if you'd like to use it, feel free. In case I forget, and I guess for anyone interested, I shall spend some time explaining how I've gone about creating my docsets. For this project, I chose Ruby (1.8.7).

I suppose the NEXT best place to start is to outline the requirements for using the Dash class:

* Ruby 1.8+
* Nokogiri 1.5.10 - I am running OS X 10.8 which is bundled with Ruby 1.8.7. I choose not to manage multiple Ruby versions on my machine. As a result, 1.5.10 is the version of Nokogiri I had to install. Version 1.6+ requires Ruby 1.9+, so it was not an option. These scripts should definitely work with the newer versions of both software, however.
* Git
* ruby-git - [A Ruby implementation for Git](https://github.com/schacon/ruby-git)


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

1. A repo is created. If one isn't, it is created for you and an initial import of all the docs is completed.
2. A "dev" branch exists. The master branch is intended to reference the original, pristine documentation. The dev branch is where all of the generator script changes take place.
3. The current HEAD points to a _clean_ dev branch. A `git reset --hard HEAD` is run to ensure a clean working tree.

It should be clear that each time the script is run, the previous changes made by the script are erased. That's OK! Borrowing a strategy from Puppet, this entire framework was created so that the changes made by the generator are _idempotent_. You should expect the same results each time you run the generator (unless you made changes to the generator of course). This is why the entire docset hierarchy is re-created on each run of the generator.


### What's So Special about YOUR Docs?

Every generator has the class require statement and needs a Dash object to be created. Once that is out of the way, you will need to analyze the structure of the documentation to determine what processing is required for the Dash entries you want. Do you want Dash to know about Guides? Do you want to document options as well as the commands they are associated with? All of that, and more, is up to you. Let's continue with the Puppet use case.

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
