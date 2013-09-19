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

**resources** - Project templates and other random resources that are used to generate the docsets.

**src** - This folder is hidden and isn't referenced in any generator. It is only a place where compressed files of the src-docs live. I only mention it because it exists in the .gitignore file.

**src-docs** - Each project has source documentation in the form of a single folder containing a collection of HTML, CSS, Javascript, and images. When you specify a docs_root in each generator script, that path is relative to this directory.

------------------------------------------------------------------------------------

PuppetDocs - A Practical Example
--------------------------------

The easiest way to explain the framework is to run through an example.

### Step 1

The first thing to do is to acquire the HTML documentation. If you are lucky, the documentation you seek will be available as a standalone, compressed file filled with structured HTML. If you are unlucky, you will have to use `wget` to crawl a URL and download everything it finds. The obvious drawback to the `wget` method is getting a whole bunch of stuff you don't need. Also, since it follows links it finds in pages when downloading files, you are never sure if you have gotten every file you need for complete documentation.

In case you have to resort to using `wget` to retrieve your documentation, here is the command I have been using:

    wget -nv -e robots=off -o wget.nv.log -r -nc -p http://docs.domain.com/latest

* `-nv` No verbose. This makes the output a bit cleaner. You will be downloading quite a few files after all.
* `-e robots=off` Execute command. Commands are whatever you can put in `~/.wgetrc`. In this case, we are ignoring the robots.txt file.
* `-o` Output file. Duh. ;]
* `-r` Recursive. Gotta make sure you can move through the directory hierarchy.
* `-nc` No-clobber. If the file has already been downloaded, don't download it again. This is important because usually every HTML file references the same CSS, Javascript, and even some images. You definitely don't want to waste time downloading the same resources over and over. This is also useful in case your download is halted for some reason and you want to start it back up again.
* `-p` Page requisites. Tell wget to download stylesheets, scripts, images, and anything else necessary to display the page correctly offline.

Once you have the documentation, you will need to copy it into the `src-docs` folder. Let's use Puppet as an example. The docs for Puppet were available as a standalone, compressed file (hooray!). It's basically the entire docs.puppetlabs.com site. I copied the documentation folder into `more-dash-docsets/src-docs/puppetdocs-latest`. The `puppetdocs-latest` folder contains the index.html that is the starting point for all docs, and each module in it's own folder.


### Step 2

The next step is to create the generator script.
