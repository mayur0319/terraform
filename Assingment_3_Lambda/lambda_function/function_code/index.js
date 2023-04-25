const movies = [
	"Hello From Lambda Function"
];
exports.handler = async (event) => {
	return {
		statusCode: 200,
		headers: {
			"Content-Type": "application/json",
		},
		body: JSON.stringify({ movies }),
	};
};