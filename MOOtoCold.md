# Introduction
So you've been using MOO for 30 years and have decided you need a change of pace. Good for you! This guide will help familiarize you with the ColdCore programmer conventions as they compare to the MOO versions. Primarily, it will focus on commands that help you explore. Once you can dig around, learning becomes much easier!

You'll find a lot of similarities exist, which is helpful. For example, `@list` works basically the same. You just have to replace `:` with `.` (one indicates MOO verb, the other indicates ColdC method). `@edit` similarly works the same.

When in doubt, try `HELP`! The help files contains references for common actions and specific commands. Even when you know a command, the help file will often have specific arguments / flags that you'd otherwise miss out on.

# Terminology
| Term            | Definition                | MOO Equivalent |
| --------------- | ------------------------- | -------------- |
| ColdC           | The programming language. | MOO            |
| Genesis         | The driver / server.      | ToastStunt     |
| ColdCore        | The database.             | ToastCore      |
| Method          | A chunk of code.          | Verb           |
| Object Variable | Holds a value.            | Property       |


# Commands
| MOO Command            | ColdCore Command              | Function                                           |
| ---------------------- | ----------------------------- | -------------------------------------------------- |
| `@d <object>:`         | `@d <object>.`                | List verbs (methods) on \<object\>.                |
| `@d <object>.`         | `@d <object>,`                | View properties (object variables) on \<object\>.  |
| `@grep toast`          | `@grep +d +f toast $root`     | Search all verbs (methods) for the string `toast`. |
| `@forked`              | `@tasks`                      | View background and suspended tasks.               |
| `@linelength <length>` | `@set me:cols=<length>`       | Set linelength to \<length\>                       |
| `@edito +local`        | `@set me:local-editor=mcp`    | Enable local editing.                              |
| `@ansi-o +all`         | `@set content-type=text/ansi` | Enable ANSI.                                       |
| `@shutdown in 0`       | `@shutdown +t=0`              | Shut down right now.                               |

# Commands With No Exact Equivalent That Are Nevertheless Important
| ColdCore Command                    | Function                                                                                   |
| ----------------------------------- | ------------------------------------------------------------------------------------------ |
| `@commands <object>`                | Show command line commands on an object. Add `+f` to see the method called by the command. |
| `@which <command>`                  | Show the method underlying a command line command.                                         |
| `;as <object> <variable> = <value>` | Directly set the value of an object variable without a setter.                             |
| `@mojo on`                          | Gives you the equivalent of wizardly powers.                                               |
| `@set <object>:`                    | View a list of settings for \<object\>.                                                                                           |

# Methods
| MOO Verb / Function           | ColdCore Method            | Function                                           |
| ----------------------------- | -------------------------- | -------------------------------------------------- |
| `confunc`                     | `.login`                   | Called when a player connects.                     |
| `isa(<object>, <parent>)`     | `<object>.is(<parent>)`    | Check if \<object\> is a descendant of \<parent\>. |
| `suspend(<time>)`             | `$scheduler.sleep(<time>)` | Suspend the task for \<time\> seconds.             |
| `connected_players()`         | `$user_db.connected()`     | List connected players.                            |
| `$command_utils:read_lines()` | `<object>.read()`          | Read input from \<object\> and return as a list.   |

# Gotchas
- When using eval, don't forget that you still have to declare local variables. e.g. `;var x; for x in [1..5] .tell("" + x);
- **WARNING**: When you update the Genesis binary, your database will likely be inaccessible by the new version! It's important to 1.) Decompile your binary database into a textdump before updating. I also do it as part of the shutdown script and during regular backups. 2.) Just in case, back up your old Genesis binary.
- You don't directly add methods. The simple act of invoking `@edit` is what adds a method.
- Unlike MOO, you can't just add a method and then start calling it from the command line immediately. You have to add it as a command first. See [Adding Commands](#Adding-Commands) below.

# Adding Commands
1. Add the method to the object that will house the command. It should end in \_cmd if it's going to be called from the command line. Also, you know, program it.
2. Use `@add-command` to add what you type on the command line and link it to the \_cmd. Example: `@add-command "@vsearch|@msearch|@method-s?earch <any>" to me.vsearch_cmd`
3. Update your local command cache: `@rehash`

It would be useful to reference the help files for: `@add-command` and `Enhanced Command Templates`

# Neat Things
- Eval has a number of interesting options for debugging and profiling code. `HELP @EVAL` explains them in the 'Execution Flags' section.
- `.tell()` doesn't seem quite as robust as MOO's `:tell()` when it comes to types. A handy trick to avoid having to `tostr()` something is to concatenate it with a blank string. e.g. `.tell("" + x)` rather than `.tell(tostr(x))`. Mostly useful for those throwaway evals, I think, but good to know.

# Other Stuff
Now it's time to graduate to learning about Genesis-specific topics!

- [[Databases]]
- [[Starting, Stopping, Maintaining Genesis]]
