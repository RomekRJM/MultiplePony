const randomName = () => {
	let colors = [
		"red", "teal", "orange", "magenta", "blue", "green", "purple", "pink", "black", "brown", "white", "yellow",
		"grey", "olive", "amber", "azure", "beige", "violet", "fuchsia", "gold", "silver"
	];

	let color = colors[Math.floor(Math.random() * colors.length)];
	let number = Math.floor(Math.random() * 10);

	return color + number;
}