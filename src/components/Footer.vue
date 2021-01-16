<template>
	<div class="footer">
		<p>
			Built by
			<a
				href="https://twitter.com/CL_Rothschild"
				target="_blank"
				rel="noopener"
				class="link"
			>
				Connor Rothschild</a
			>
		</p>
	</div>
</template>

<script>
export default {
	name: "TopLevelText",
	props: {
		dataLength: Number,
		selected: String,
	},
	data() {
		return {};
	},
	mounted() {},
	watch: {},
	computed: {},
	methods: {},
};
</script>

<style scoped>
.footer {
	position: fixed;
	bottom: 0;
	width: 100%;
	background-color: white;
	color: black;
	text-align: center;
	padding: 15px;
	text-align: right;
}

.link {
	text-decoration: underline;
}
</style>
