using BinDeps

@BinDeps.setup

libvofi = library_dependency("libvofi", aliases=["libvofi", "libvofi.so"], os=:Unix)

#link = "https://github.com/vlc1/Vofi/files/1521553/Vofi-v1.0jl.tar.gz"
#link = "https://github.com/vlc1/vofi/archive/v1.0jl.tar.gz"
sha = "5bfaf9432624cafbd89d63e733e5a5569ba6ca4d"
link = "https://github.com/vlc1/Vofi/archive/$(sha).tar.gz"

provides(Sources, URI(link), [libvofi], unpacked_dir="Vofi-$(sha)")

prefix = joinpath(BinDeps.depsdir(libvofi), "usr")
srcdir = joinpath(BinDeps.srcdir(libvofi), "Vofi-$(sha)")

provides(SimpleBuild,
	(@build_steps begin
		GetSources(libvofi)
		CreateDirectory(joinpath(prefix, "lib"))
		@build_steps begin
			ChangeDirectory(srcdir)
			`./configure --prefix=$(prefix)`
			`make`
			`make install`
		end
	end), [libvofi], os=:Unix)
#provides(BuildProcess, Autotools(libtarget = joinpath("src", "libvofi.so")), libvofi, os=:Unix)

@BinDeps.install Dict(:libvofi => :libvofi)

