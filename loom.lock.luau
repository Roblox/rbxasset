return {
  version = 2,
  dependencies = {
    ["Lute@v1.0.0"] = {
      installPath = "Packages/Lute@v1.0.0",
      name = "Lute",
      rev = "v1.0.0",
      source = "https://github.com/luau-lang/lute",
      sourceKind = "github",
      dependencies = {},
    },
    ["t@v3.0.0"] = {
      installPath = "Packages/t@v3.0.0",
      name = "t",
      rev = "v3.0.0",
      source = "https://github.com/osyrisrblx/t",
      sourceKind = "github",
      dependencies = {},
    },
  },
  packages = {"Lute@v1.0.0", "t@v3.0.0"},
}
