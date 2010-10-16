//if not ADDON_PROP then return end

ADDON_PROP = {}
table.insert( ADDON_PROP, "cl_sharpeye_base.lua" )

local HAYFRAME_DIR = "sharpeye_hayframe/"
table.insert( ADDON_PROP, HAYFRAME_DIR .. "hayframe__initializer.lua" )
table.insert( ADDON_PROP, HAYFRAME_DIR .. "hayframe_util.lua" )
table.insert( ADDON_PROP, HAYFRAME_DIR .. "hayframe_var.lua" )
table.insert( ADDON_PROP, HAYFRAME_DIR .. "hayframe_cmds.lua" )
table.insert( ADDON_PROP, HAYFRAME_DIR .. "hayframe_mediator.lua" )
table.insert( ADDON_PROP, HAYFRAME_DIR .. "hayframe_changelog.lua" )
table.insert( ADDON_PROP, HAYFRAME_DIR .. "hayframe_ctrlcolor.lua" )
table.insert( ADDON_PROP, HAYFRAME_DIR .. "hayframe_context.lua" )

table.insert( ADDON_PROP, "cl_sharpeye_ground.lua" )
table.insert( ADDON_PROP, "cl_sharpeye_motion.lua" )
table.insert( ADDON_PROP, "cl_sharpeye_focus.lua" )
table.insert( ADDON_PROP, "cl_sharpeye_sound.lua" )
table.insert( ADDON_PROP, "cl_sharpeye_vision.lua" )

table.insert( ADDON_PROP, "cl_sharpeye_wiimote.lua" )
table.insert( ADDON_PROP, "cl_sharpeye_compatibility.lua" )
//table.insert( ADDON_PROP, "cl_sharpeye_backup.lua" )
table.insert( ADDON_PROP, "cl_sharpeye_menu.lua" )

//table.insert( ADDON_PROP, "cl_sharpeye_legacy.lua" )
