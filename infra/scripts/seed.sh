#!/usr/bin/env bash
# Seed the database.
#
#   ./scripts/seed.sh                     run DatabaseSeeder
#   ./scripts/seed.sh --class=LessonSeeder  run one seeder
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

wait_for_mysql

artisan db:seed --force "$@"

echo "Seeding complete."
