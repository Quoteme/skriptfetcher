import Init.System.FilePath

structure URL where
  protocol : String
  host : String
  path : System.FilePath
  deriving Inhabited, Repr

def URL.toString (url : URL) : String :=
  s!"{url.protocol}://{url.host}/{url.path}"

instance : ToString URL := ⟨URL.toString⟩

def URL.fromString (s : String) : Option URL := do
  let parts := s.splitOn "://"
  if parts.length ≠ 2 then none
  else
    let protocol := parts.get! 0
    let rest := parts.get! 1
    let parts := rest.splitOn "/"
    let host := parts.get! 0
    let path := System.FilePath.mk <| parts.drop 1 |> String.intercalate "/"
    some { protocol := protocol, host := host, path := path }

def URL.download (url : URL) (file : System.FilePath) : IO IO.Process.Output := do
  IO.Process.output {cmd := "curl", args := #["-o", file.toString, url.toString]}

structure Skript where
  url : URL
  name : String
  author : String
  year : Nat
  deriving Inhabited, Repr

def Skript.fileName (skript : Skript) : System.FilePath :=
  System.FilePath.mk s!"{skript.name} - {skript.author} ( {skript.year} ).pdf"

def Skript.toString (skript : Skript) : String :=
  s!"{skript.name} by {skript.author} ({skript.year})"

instance : ToString Skript := ⟨Skript.toString⟩

def Skript.download (skript : Skript) (file : System.FilePath) : IO IO.Process.Output :=
  URL.download skript.url file

def sources : List Skript := [
  {
    url := URL.fromString "https://reh.math.uni-duesseldorf.de/~internet/MT-V-W22/kurzskript.pdf" |>.get!,
    name := "Einführung in die Modelltheorie",
    author := "Prof. Immanuel Halupczok",
    year := 2022
  },
  {
    url := URL.fromString "https://www.math.uni-duesseldorf.de/~internet/MT1-V-W23/kurzskript.pdf" |>.get!,
    name := "Modelltheorie 1",
    author := "Prof. Immanuel Halupczok",
    year := 2023
  },
  {
    url := URL.fromString "https://www.math.uni-duesseldorf.de/~internet/MT2-V-S24/kurzskript.pdf" |>.get!,
    name := "Modelltheorie 2",
    author := "Prof. Immanuel Halupczok",
    year := 2024
  }
]

def main (args : List String) : IO Unit := do
  let outputDir : System.FilePath := match args.length with
    | 0 => System.FilePath.mk "./output"
    | _ => System.FilePath.mk $ args.get! 0
  if args.length = 0 then
    IO.println "You may specify the output directory as an argument."
    IO.println s!"Falling back to default ouptut directory \"{outputDir}\""
  IO.println "This script downloads the following sources:"
  for skript in sources do
    IO.println s!"- {skript.name} by {skript.author} ({skript.year})"
  IO.println s!"These will be saved in {outputDir}"
  IO.println "Downloading sources..."
  for skript in sources do
    let file := outputDir / System.FilePath.mk skript.fileName.toString
    IO.println s!"Downloading {skript}..."
    let output ← skript.download file
    IO.println s!"Downloaded {skript.name} to {file}"
    IO.println "Got output:"
    IO.println output.stdout
  IO.println "Done"
