extends Object

class_name Graph
var graph_matrix:Array

func _init(n:int):
	for x in range(n):
		graph_matrix.append([])
		for y in range(n):
			graph_matrix[x].append(0)

func add_edge(u: int, v: int):
	graph_matrix[u][v] = 1
	graph_matrix[v][u] = 1

func print_graph():
	for x in range(graph_matrix.size()):
		print(graph_matrix[x])

func count_edges(u):
	var count = 0
	for i in graph_matrix[u]:
		if i == 1:
			count += 1
	return count
	
func is_every_vertice_connected():
	for i in range(graph_matrix.size()):
		if count_edges(i) == 0:
			return false
	return true

func bfs():
	var queue:Array
	var visited:Array[bool]
	for i in range(graph_matrix.size()):
		visited.append(false)
	
	visited[0] = true
	queue.append(0)
	
	while !queue.is_empty():
		var current = queue.front()
		queue.pop_front()
		
		for i in range(graph_matrix[current].size()):
			if(visited[i] == false and graph_matrix[current][i] == 1):
				visited[i] = true
				queue.push_front(i)
				
	for bol in visited:
		print(bol)

func djikstra():
	var queue:Array
	var distances:Array[int]
	for i in range(graph_matrix.size()):
		distances.append(255)
		
	queue.push_front(0)
	distances[0]=0
	
	while !queue.is_empty():
		var current: int = queue.front()
		var current_distance = distances[current]
		queue.pop_front()
		
		for i in range(graph_matrix[current].size()):
			if graph_matrix[current][i] == 1:
				current_distance = distances[current] + 1
				if current_distance < distances[i]:
					distances[i] = current_distance
					queue.push_front(i)
	
	for dist in distances:
		print(dist)
