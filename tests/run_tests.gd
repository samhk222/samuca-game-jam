extends SceneTree

const TEST_DIR := "res://tests"


func _init() -> void:
	var failed := 0
	var passed := 0
	for file in DirAccess.get_files_at(TEST_DIR):
		if not (file.begins_with("test_") and file.ends_with(".gd")) or file == "test_case.gd":
			continue
		var script: GDScript = load(TEST_DIR.path_join(file))
		if script == null or not script.can_instantiate():
			print("FAIL %s: could not load" % file)
			failed += 1
			continue
		for method in script.get_script_method_list():
			var name: String = method.name
			if not name.begins_with("test_"):
				continue
			var test = script.new()
			test.call(name)
			if test.failures.is_empty():
				passed += 1
			else:
				failed += 1
				print("FAIL %s::%s: %s" % [file, name, "; ".join(test.failures)])
	print("%d passed, %d failed" % [passed, failed])
	quit(1 if failed > 0 else 0)
