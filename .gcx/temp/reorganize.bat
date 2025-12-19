@echo off
echo Reorganizing Platform Structure...

if not exist platform\backend mkdir platform\backend

if exist platform\src move platform\src platform\backend\
if exist platform\Cargo.toml move platform\Cargo.toml platform\backend\
if exist platform\Cargo.lock move platform\Cargo.lock platform\backend\
if exist platform\static move platform\static platform\backend\
if exist platform\templates move platform\templates platform\backend\
if exist platform\target move platform\target platform\backend\

echo Structure reorganization complete.
