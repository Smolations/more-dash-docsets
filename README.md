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

**icon-images** - A folder where I keep 32x32 images to be used as icons in the docsets.

**resources** - Project templates and other random resources that are used to generate the docsets.

**src** - This folder is hidden and isn't referenced in any generator. It is only a place where compressed files of the src-docs live. I only mention it because it exists in the .gitignore file.

**src-docs** - Each project has source documentation in the form of a single folder containing a collection of HTML, CSS, Javascript, and images. When you specify a docs_root in each generator script, that path is relative to this directory.
