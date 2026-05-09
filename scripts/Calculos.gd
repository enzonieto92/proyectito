extends Node

func chance(percent: float) -> bool:
	return randf() <= percent / 100.0
