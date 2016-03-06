Open Analytics Vagrant Box
==========================

This box provides a ready-to-use Linux box to perform machine learning, regressions, business intelligence, social network analysis, simulations and so on. It automatically installs and configures tools like Revolution R, RStudio, MySql for data storage, apache and a full development stack for R package development (Oracle JDK, git, SVN and all dependencies)

If you need a ready-to-use, zero-config, full stack for analytics and you don't want to waste time in downloading and installing the tools by yourself, this Linux box is probably what you need!

Three recipes are available to tune up the server and data_bags can be used to add users and database to the box.

What is included in the stack
-----------------------------
The provisioned server has the following features::

* **Revolution R Open Edition** from [Revolution Analytics](http://www.revolutionanalytics.com/ "Revolution Analytics") (now Microsoft). This is a very fast and stable version of the R platform, has a private and certified CRAN repository called MRAN and is typically used in machine learning. A comfortable installer for the Revolution Math multicore library is also included.
* **R Studio Server** to remotely use Revolution R. **PAM** is used as authentication method for R Studio, so there's no need to create users with SSH access for accessing the application.
* **MySql** from Oracle Corporation. A specifically tuned instance is provided for Data Science and Business Intelligence task. Users and database can be freely added using data_bags (see below for details).
*  **Apache Web Server and PHP** is added to provide a web interface for web applications, like **phpmyadmin** which is also installed and configured automatically. Apache Web Server is also used as a proxy for R Studio Server.
* **JDK 1.7** from Oracle Corporation. The VM to install (both the flavour and the version) can be set in recipes' attributes.
* **gcc, git, SVN, libc, libfortran** and any immaginable possible tool and library for installing and developing R packages.

Set-up and provision the server with default options
----------------------------------------------------
To provision and boot the server with the default setup, just type ``vagrant up`` on the command line. The provision setup would approximately last from 15 to 25 minutes, depending on your host machine and network speed.

The box forwards the http port to 8080. This means that, ff the provision step ends without errors, you'll be able to access R Studio Server pointing your browser to ``http://127.0.0.1:8080/rstudio``. On a similar way, phpmyadmin will be available on ``http://127.0.0.1:8080/phpmyadmin``.

Tune-up your server
-------------------

If you want to a deeper control on your box and you're an hardcore user, you've a lot of options you may want to tweak on. But please note that if you don't know what you're doing, the box will probably end up with an error in the provision stage.

### Server Properties ###
There are some options you may setup in the ``Vagrantfile``. These settings allow you to add or remove resource to the Linux box, for example if you need a bigger or a smaller box to better suit your needs.

Just have a look and edit following your needs this block at the beginning of the ``Vagrantfile``:

    # Configuration parameters
    ram = 4096								# Ram in MB 
    hostname = "analytics"					# The hostname for the box
    machineName = "Open Analytics Stack"  	# The machine name (for VirtualBox only)
    cpus = 4  								# Number of cores

### Analytics Tools Properties ###

To tune-up the setup of the various tools and applications provisioned by Vagrant, just edit the role file located at ``roles/analytics.rb``.

The first part of the file is a set of attributes to override from the default values:
    
    override_attributes(
    "users" => ["jdoe"],
    "rro" => {
      "version" => "3.2.2"
    },
    "rstudio" => {
      "version" => "0.99",
      "rserver" => {
    "group" => "rstudio"
      },
    "rsession" => {
      "session-timeout" => 30
      }
    }

    [...]

Feel free to add/change/delete any item here, but be careful that you'll end up with a valid key-value array. The provision stage will break out otherwise!

You may have a look at the default values for some attributes on the file ``/cookbooks/analytics/attributes/default.rb``, but even more attributes to set are available on each cookbook (for *really* expert users, or for those having a lot of spare time!)

The second part of the role files let you comment/uncomment the elements you don't need, to speed up the provision process:
    
    run_list(
    	"recipe[system]",
    	"recipe[analytics::default]",
    	"recipe[analytics::mysql]",
    	"recipe[analytics::rstudio]"
    )

Please note that the **system** and the **analytics::default** recipes are mandatory. The box will fail if these are commented out!
