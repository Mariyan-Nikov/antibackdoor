fx_version 'cerulean'
game 'gta5'

author 'Your Name / Development'
description 'QB-AntiBackdoor - Dynamic Server Security Monitor'
version '1.0.0'

-- Ensures QBCore handles its initialization steps before this resource attaches hooks
dependencies {
    'qb-core'
}

server_script 'server.lua'