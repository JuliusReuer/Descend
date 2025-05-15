class_name ThreadHelper


static func start(threads: int, array: Array, executor: Callable) -> bool:
	threads = max(threads, 1)
	var thread_list: Array[Thread] = []
	var part = len(array) / threads
	for i in threads - 1:
		thread_list.append(Thread.new())
		var thread = func():
			for j in range(part):
				executor.call(j + i * part)
		thread_list[i].start(thread)
	thread_list.append(Thread.new())
	var thread = func():
		var offset = (threads - 1) * part
		for j in range(len(array) - offset):
			executor.call(j + offset)
	thread_list[threads - 1].start(thread)
	var success: bool = true
	for cur_thread in thread_list:
		if !cur_thread.wait_to_finish():
			success = false
	return success
