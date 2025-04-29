using AtlansApi
using Documenter
using DocumenterMarkdown


makedocs(
	sitename = "AtlansApi.jl",
	format = Markdown(),
	authors = "Deltares and contributors",
	modules = [AtlansApi],
)
