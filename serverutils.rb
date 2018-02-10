require 's3'
require 'git'
require 'octokit'

class	String
	def ghrepo
		name = self.split("/")[1]
		return name
	end
end

class	String
	def clone(url)
		g = Git.init
		g.clone(url, self.ghrepo, :path => self.ghrepo)
	end
end

def run_check(name, file)
	cmds = "cd %s \n sudo docker run --rm -ti -v $(pwd):/data -w /data rocker/verse:devel Rscript -e 'devtools::install_github(\"MangoTheCat/goodpractice\"); devtools::install(); Sys.setenv(NOT_CRAN = \"true\"); x <- goodpractice::gp(); goodpractice::export_json(x, %s)'" % [name, file]
	system cmds
end

def prepare_report(name, file)
	puts "not ready yet"
end

class	String
	def to_s3
		file = "gp_report.json" % self.ghrepo
		cmd = "aws s3 cp %s s3://rcheckbuilds" % file
		system cmd
		return url
	end
end
