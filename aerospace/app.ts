export async function reload_aerospace() {
  const cmd = new Deno.Command("aerospace", {
    args: ["reload-config"],
  });

  const res = await cmd.spawn().status;

  if (!res.success) {
    throw new Error(`Reloading aerospace failed with code ${res.code}`);
  }
}
