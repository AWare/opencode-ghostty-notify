// ghostty-notify.ts — opencode plugin for Ghostty terminal notifications
//
// Sends a bell + OSC 777 notification to the parent Ghostty terminal on:
//   session.idle       — agent finished responding
//   session.error      — agent hit an error
//   permission.updated — opencode is waiting for permission approval
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
      } else if (event.type === "session.error") {
        await notify("Error")
      } else if (event.type === "permission.updated") {
        await notify("Needs permission")
      }
    },
  }
}

export default GhosttyNotifications
