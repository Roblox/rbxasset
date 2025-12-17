local t = require("@pkg/t")

local types = {}

local function countObject(obj: { [any]: any }): number
	local count = 0
	for _ in obj do
		count += 1
	end
	return count
end

export type AssetType = "Package" | "Plugin"
export type CreatorType = "User" | "Group"
export type AssetId = string | number

export type AssetConfig = {
	-- Name of the asset that will be displayed on the Creator Store
	name: string,

	-- Path of the rbxm file to upload
	model: string,

	-- The environment to deploy to. For example, if `[environments.production]`
	-- is specified in `rbxasset.toml`, then this value should be "production"
	environment: string,

	type: AssetType?,

	-- Description of the asset on the Creator Store
	description: string?,

	-- Path to the image to use for the asset's icon on the Creator Store. This
	-- must be a png.
	icon: string?,

	-- Paths to images to use for the asset's previews on the Creator Store.
	thumbnails: { string }?,
}
types.validateAssetConfig = t.strictInterface({
	name = t.string,
	model = t.string,
	environment = t.string,

	type = t.optional(t.union(t.literal("Package"), t.literal("Plugin"))),
	description = t.optional(t.string),
	icon = t.optional(t.string),
	thumbnails = t.optional(t.array(t.string)),
})

export type EnvironmentConfig = {
	creatorId: number,
	creatorType: "User" | "Group",
	universeId: number,
	placeId: number,
}
types.validateEnvironmentConfig = t.strictInterface({
	creatorId = t.union(t.string, t.number),
	creatorType = t.union(t.literal("User"), t.literal("Group")),
	universeId = t.number,
	placeId = t.number,
})

export type Manifest = {
	assets: {
		[string]: AssetConfig,
	},
	environments: {
		[string]: EnvironmentConfig,
	},
}
types.validateManifest = function(value: any): (boolean, string?)
	local success, message = t.strictInterface({
		assets = t.map(t.string, types.validateAssetConfig),
		environments = t.map(t.string, types.validateEnvironmentConfig),
	})(value)

	if not success then
		return success, message
	end

	if typeof(value.assets) == "table" and countObject(value.assets) == 0 then
		return false, "at least one asset must be defined in the manifest"
	end

	if typeof(value.environments) == "table" and countObject(value.environments) == 0 then
		return false, "at least one environment must be defined in the manifest"
	end

	for key, asset in value.assets do
		-- MUS-2488 TODO: Remove this check once Open Cloud supports Plugin asset types
		if asset.type == "Plugin" then
			return false, "plugin asset types are not yet supported by Open Cloud"
		end

		if not value.environments[asset.environment] then
			return false, `asset "{key}" attempts to use the environment "{asset.environment}" which does not exist`
		end
	end

	return true, nil
end

type ImageLock = {
	assetId: string,
	hash: string,
}
types.validateImageLock = t.strictInterface({
	assetId = t.string,
	hash = t.string,
})

type AssetLock = {
	assetId: string,
}
types.validateAssetLock = t.strictInterface({
	assetId = t.string,
	images = t.optional(t.map(
		t.string,
		t.strictInterface({
			assetId = t.string,
			hash = t.string,
		})
	)),
})

export type Lockfile = {
	assets: {
		[string]: AssetLock,
	},
	images: { [string]: ImageLock },
}
types.validateLockfile = t.strictInterface({
	assets = t.map(t.string, types.validateAssetLock),
	images = t.map(t.string, types.validateImageLock),
})

export type ErrorStatusResponse = {
	code: string,
	message: string,
	details: { string }?,
}

export type OperationResponse = {
	done: boolean,
	operationId: string,
	path: string,

	-- Success
	response: { [string]: any }?,

	-- Failure
	error: ErrorStatusResponse?,
	metadata: {
		errors: {
			{
				error: ErrorStatusResponse,
				fieldMask: { [string]: any },
			}
		},
	}?,
} & ErrorStatusResponse

return types
