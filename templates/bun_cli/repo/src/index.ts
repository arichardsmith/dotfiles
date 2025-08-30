#!/usr/bin/env bun

import { intro, text, log, isCancel, outro, spinner } from "@clack/prompts";

async function main() {
	intro("An example cli app using clack for input");

	const target = await text({
		message: "Who should we greet?"
	});

	if (isCancel(target)) {
		log.warn("User canceled");
		return;
	}

	const s = spinner();
	s.start("Wait for it");

	await new Promise((resolve) => setTimeout(resolve, 1000));
	s.stop("Waited a sec");

	log.info(`Hello ${target}`);

	outro("Clack demonstrated");
}

main().catch((error) => {
	log.error(error);
	process.exit(1);
});
