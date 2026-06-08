class_name ParticleEffectManager extends Node

func effect_activation(card : CombinedCard) -> void:
	const EFFECT_ACTIVATION_PARTICLES := preload("uid://dd1ld8barxax")
	var new_particles = EFFECT_ACTIVATION_PARTICLES.instantiate()
	new_particles.global_position = card.global_position
	card.add_child(new_particles)
	new_particles.emitting = true
