-- plugin to get the tabs for the open buffers


return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  event = "BufReadPre",
  opts = {
    options = {
      offsets = {
        {
          filetype = "NvimTree",
        },
      },
    },
  },
}





