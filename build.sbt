name := "spark-on-ecs"

version := "v1.0"

scalaVersion := "2.12.10"

resolvers ++= Seq(
  "Artima Maven Repository" at "http://repo.artima.com/releases",
  "scala-tools" at "https://oss.sonatype.org/content/groups/scala-tools",
  "Typesafe repository" at "http://repo.typesafe.com/typesafe/releases/",
  "Second Typesafe repo" at "http://repo.typesafe.com/typesafe/maven-releases/",
  Resolver.sonatypeRepo("public")
)
//resolvers += "Typesafe Repository" at "http://repo.typesafe.com/typesafe/releases/"

// additional librairies
libraryDependencies ++= {
  Seq(
    "org.apache.spark" %% "spark-core" % "2.4.5" % "provided",
    "org.apache.spark" %% "spark-sql" % "2.4.5" % "provided",
    "org.apache.hadoop" % "hadoop-aws" % "2.7.1",
    //"com.amazonaws" % "aws-java-sdk" % "1.7.4",
    "com.amazonaws" % "aws-java-sdk" % "1.11.696",
    "org.scalactic" %% "scalactic" % "3.0.7",
    "org.scalatest" %% "scalatest" % "3.0.7" % Test
  )
}

// Resolve duplicates for Sbt Assembly
assemblyMergeStrategy in assembly := {
  case PathList(xs@_*) if xs.last == "io.netty.versions.properties" => MergeStrategy.rename
  case other => (assemblyMergeStrategy in assembly).value(other)
}


assemblyShadeRules in assembly := Seq(
  ShadeRule.rename("org.apache.commons.beanutils.**" -> "shaded-commons.beanutils.@1").inLibrary("commons-beanutils" % "commons-beanutils-core" % "1.8.0"),
  ShadeRule.rename("org.apache.commons.collections.**" -> "shaded-commons.collections.@1").inLibrary("commons-beanutils" % "commons-beanutils-core" % "1.8.0"),
  ShadeRule.rename("org.apache.commons.collections.**" -> "shaded-commons2.collections.@1").inLibrary("commons-beanutils" % "commons-beanutils" % "1.7.0"),
)

// testing configuration for Spark-testing-base package
fork in Test := true
javaOptions ++= Seq("-Xms512M", "-Xmx2048M", "-XX:MaxPermSize=2048M", "-XX:+CMSClassUnloadingEnabled")
parallelExecution in Test := false
