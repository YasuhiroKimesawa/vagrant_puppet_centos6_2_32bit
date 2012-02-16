import 'cpan2rpm.pp'

class format_centos6 {
     exec { 'yum update':
          path   => '/usr/bin',
          command => "yum -y update",
		  timeout => 0,
     }

     /* yum-cronÝ’è */
     package { 'yum-cron':
          name => "yum-cron",
          ensure => installed
     }

     service { 'yum-cron':
          enable  => true,
          ensure  => running,
          require => Package['yum-cron'],
     }

     exec { 'chkconfig yum-cron on':
          path    => '/sbin',
          command => "chkconfig yum-cron on",
          require => Service['yum-cron']
     }

	/* iptable’âŽ~ */
	exec { 'iptables':
		  path    => '/etc/init.d/',
          command  => "iptables stop",
     }

	/* EPELƒŒƒ|ƒWƒgƒŠ */
     exec { 'groupinstall Base Development tools':
          path   => '/usr/bin',
          timeout => 0,
          command => "yum -y groupinstall 'Base' 'Development tools' --exclude=perl-Git-1.7.4.1-1.el5.i386 --exclude=python-ethtool-0.6-2.el5.i386 --exclude=git-1.7.4.1-1.el5.i386"
     }

	package { 'yum-plugin-priorities':
			name   => "yum-plugin-priorities",
			ensure => "installed"
	}

	file { '/etc/yum.repos.d/CentOS-Base.repo':
		mode    => 644,
		owner   => 'root',
		group   => 'root',
		source  => '/vagrant/manifests/files/CentOS-Base.repo',
		require => Package['yum-plugin-priorities']
	}

	exec { 'rpm EPEL':
		path    => '/bin',
		timeout => 0,
		command => "rpm -Uvh http://download.fedora.redhat.com/pub/epel/6/i386/epel-release-6-5.noarch.rpm",
		require => File['/etc/yum.repos.d/CentOS-Base.repo'],
		creates => "/etc/yum.repos.d/epel.repo";
	}

	file { '/etc/yum.repos.d/epel.repo':
		mode    => 644,
		owner   => 'root',
		group   => 'root',
		source  => '/vagrant/manifests/files/epel.repo',
		require => Exec['rpm EPEL'],
	}

	exec { 'yum update epel-release':
		path    => '/usr/bin',
		timeout => 0,
		command => "yum -y update epel-release",
		require => File['/etc/yum.repos.d/epel.repo'],
	}

	/* RPMforge */
	exec { 'rpm RPMforge':
		path    => '/bin',
		timeout => 0,
		command => "rpm -Uvh http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.i686.rpm",
		require => File['/etc/yum.repos.d/epel.repo'],
		creates => "/etc/yum.repos.d/rpmforge.repo";

			'yum update RPMforge-release':
		path    => '/usr/bin',
		timeout => 0,
		command => "yum -y update rpmforge-release",
		require => Exec['rpm RPMforge']
	}

	/* JPackage	 */
	exec { 'rpm JPackage':
		path    => '/bin',
		timeout => 0,
		command => "rpm -Uvh http://mirrors.dotsrc.org/jpackage/6.0/generic/free/RPMS/jpackage-utils-5.0.0-7.jpp6.noarch.rpm",
		require => File['/etc/yum.repos.d/epel.repo'],
		creates => "/var/cache/yum/i386/6/jpackage-generic"
	}

	/* apache install */
	package { 'apache':
          name   => "httpd",
          ensure => installed
     }

	package { 'php':
          name   => "php",
          ensure => installed
     }

	package { 'php-mbstring':
          name   => "php-mbstring",
          ensure => installed
     }

	service { 'httpd':
          enable  => true,
          ensure  => running,
          require => Package['apache'],
     }

	/* java install */
	exec { 'java install':
		path	=> '/bin',
		command => "/vagrant/manifests/files/jdk-6u25-linux-i586-rpm.bin",
		creates => "/usr/java/jdk1.6.0_25/jre/bin",
		require => Exec['rpm JPackage'],
	}

	file { '/etc/profile':
		mode    => 644,
		group   => '0',
		owner   => '0',
		source  => '/vagrant/manifests/files/profile',
		require => Exec['java install']
	}

	exec { 'source /etc/profile':
		path    => '/bin/bash',
		command => '/bin/bash -c "source /etc/profile"',
		require => File['/etc/profile']
	}

	/* tomcat install */
	package { 'tomcat6':
          name   => "tomcat6",
          ensure => installed,
		  require => Exec['java install'],
     }

	package { 'tomcat6-webapps':
          name   => "tomcat6-webapps",
          ensure => installed,
		  require => Exec['java install'],
     }

	package { 'tomcat6-admin-webapps':
          name   => "tomcat6-admin-webapps",
          ensure => installed,
		  require => Exec['java install'],
     }

	file{   '/etc/tomcat6/tomcat-users.xml':
		mode    => 777,
		group   => 'tomcat',
		owner   => 'tomcat',
		source  => '/vagrant/manifests/files/tomcat-users.xml',
		require =>Package['tomcat6'],
	}

	service { 'tomcat6':
          enable  => true,
          ensure  => running,
          require => Package['tomcat6'],
     }

	/* jenkins */
	file{   '/var/lib/tomcat6/webapps/jenkins.war':
		mode    => 777,
		group   => 'tomcat',
		owner   => 'tomcat',
		source  => '/vagrant/manifests/files/jenkins.war',
		require =>Package['tomcat6'],
	}

	/* subversion */
	package { 'subversion':
		name   => "subversion",
		ensure => installed,
		require => Exec['java install'],
	}

	package { 'mod_dav_svn':
		name    => "mod_dav_svn",
		ensure => installed,
		require => Package['subversion'],
	}

	file { '/var/www/svn':
		mode    => 777,
		group   => 'apache',
		owner   => 'apache',
		ensure => directory,
		require => Package['subversion'],
	}

	exec{ 'apache restart':
		path    => '/etc/rc.d/init.d',
		command => 'httpd reload',
		require => File['/var/www/svn'],
	}

	/* ant */
	package { 'ant':
		name   => "ant",
		ensure => installed,
		require => Exec['java install'],
	}

	package { 'ant-junit':
		name   => "ant-junit",
		ensure => installed,
		require => Package['ant'],
	}

}

node default {
     include format_centos6
	 include cpan2rpm

}
