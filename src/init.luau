local types = require("@self/types")

export type Manifest = types.Manifest

return {
	publishPackageAsync = require("@self/requests/publishPackageAsync"),
	publishWorkspaceAsync = require("@self/requests/publishWorkspaceAsync"),
}
