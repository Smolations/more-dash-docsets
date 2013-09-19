more-dash-docsets
=================

Greetings. I found myself excited about Dash and the prospect of creating my own docsets, so I set out to create a loose framework to do just that. I didn't build it for anyone but myself, but if you'd like to use it, feel free. In case I forget, and I guess for anyone interested, I shall spend some time explaining how I've gone about creating my docsets. For this project, I chose Ruby (1.8.7).

I suppose the best place to start is the file structure:

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

* `-nv` No verbose. This makes the output a bit cleaner. You will be downloading quite a few files after all.
* `-e robots=off` Execute command. Commands are whatever you can put in `~/.wgetrc`. In this case, we are ignoring the robots.txt file.
* `-o` Output file. Duh. ;]
* `-r` Recursive. Gotta make sure you can move through the directory hierarchy.
* `-nc` No-clobber. If the file has already been downloaded, don't download it again. This is important because usually every HTML file references the same CSS, Javascript, and even some images. You definitely don't want to waste time downloading the same resources over and over. This is also useful in case your download is halted for some reason and you want to start it back up again.
* `-p` Page requisites. Tell wget to download stylesheets, scripts, images, and anything else necessary to display the page correctly offline.

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
