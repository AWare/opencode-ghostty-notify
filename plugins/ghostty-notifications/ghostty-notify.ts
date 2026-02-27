// ghostty-notify.ts — opencode plugin for Ghostty terminal notifications
//
// Sends a bell + OSC 777 notification to the parent Ghostty terminal
// when the opencode session goes idle (agent finishes responding).
//
// Install: copy this file AND ghostty-notify.sh to .opencode/plugins/ in your
// project, or to ~/.config/opencode/plugins/ for global use.

export const GhosttyNotifications = async ({ $ }: { $: any }) => {
  const script = import.meta.dir + "/ghostty-notify.sh"

  const notify = async (msg: string) => {
    await $`bash ${script} ${msg}`.quiet().nothrow()
  }

  return {
    event: async ({ event }: { event: { type: string } }) => {
      if (event.type === "session.idle") {
        await notify("Done")
      }
    },
  }
}

export default GhosttyNotifications
