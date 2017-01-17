name "analytics"

override_attributes(
    "rstudio" => {
      "version" => "1.0.136",
    "rsession" => {
      "session-timeout" => 30
      }
    },
    "r" => {
      "version" => nil,
      "cran_mirror" => "https://cran.stat.unipd.it/"
    },
    "apache" => {
      "prefork" => {
        "startservers" => 2,
        "serverlimit" => 3,
        "maxclients" => 4
      }
    },
    "java" => {
        "install_flavor" => "oracle",
        "jdk_version" => 8,
        "oracle" => {
                "accept_oracle_download_terms" => true
        }
    },
    "mariadb" => {
        "server_root_password" => "vagrant",
        "forbid_remote_root" => false,
        "use_default_repository" => true
    }
)

run_list(
    "recipe[system::default]",
    "recipe[analytics::default]",
    "recipe[analytics::mariadb]",
    "recipe[analytics::rstudio]",
    "recipe[os-hardening::default]"
)