name "analytics"

override_attributes(
    "rro" => {
      "version" => "3.2.3"
    },
    "rstudio" => {
      "version" => "0.99.892",
      "rserver" => {
        "group" => "rstudio"
      },
    "rsession" => {
      "session-timeout" => 30
      }
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
    "mysql" => {
        "initial_root_password" => "vagrant",
        "options" => {
          "transaction-isolation" => "READ-COMMITTED",
          "key_buffer" => "16M",
          "key_buffer_size" => "32M",
          "max_allowed_packet" => "16M",
          "thread_stack" => "256K",
          "thread_cache_size" => "64",
          "query_cache_limit" => "8M",
          "query_cache_size" => "64M",
          "query_cache_type" => "1",
          "max_connections" => "550",
          "log-bin" => "/var/lib/mysql/logs/binary/mysql_binary_log",
          "binlog_format" => "mixed",
          "read_buffer_size" => "2M",
          "read_rnd_buffer_size" => "16M",
          "sort_buffer_size" => "8M",
          "join_buffer_size" => "8M",
          "innodb_file_per_table" => "1",
          "innodb_flush_log_at_trx_commit" => "2",
          "innodb_log_buffer_size" => "64M",
          "innodb_buffer_pool_size" => "4G",
          "innodb_thread_concurrency" => "8",
          "innodb_flush_method" => "O_DIRECT",
          "innodb_log_file_size" => "512M"
        }
    }
)

run_list(
    "recipe[system]",
    "recipe[analytics::default]",
    "recipe[analytics::mysql]",
    "recipe[analytics::rstudio]",
    "recipe[analytics::pam]"
)