#!/bin/sh
# Runs the headless GDScript test suite; exits non-zero on any failure.
cd "$(dirname "$0")/.." && exec ./scripts/godot --headless --script res://tests/run_tests.gd
