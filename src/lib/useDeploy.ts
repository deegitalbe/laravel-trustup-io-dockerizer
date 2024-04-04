#!/usr/bin/env node

import {
  useConfirm,
  useCurrentPath,
  useGenerator,
  useDisplayJson,
  usePackageStubsPath,
  usePrompt,
  useSentence,
  useLastFolderName,
} from "@henrotaym/scaffolding-utils";

const useStubsPath = usePackageStubsPath(
  "@deegital/laravel-trustup-io-dockerizer"
);

const useCancelSentence = () => useSentence("Scaffolding was cancelled ❌");

const useScaffolding = () => {
  useSentence("Hi there 👋");
  useSentence("Let's scaffold a new laravel dockerization 🎉");
  const isCorrectlyLocated = useConfirm(
    "Is your app located in docker integration projects folder ? "
  );

  if (!isCorrectlyLocated) {
    useCancelSentence();
    useSentence("Move your app to docker-integration/projects first 🚚");
    return;
  }

  useSentence("Great ! We can start working 👷");

  const folder = usePrompt("Folder location [.]", ".");
  const location = useCurrentPath(folder);
  const defaultAppKey = useLastFolderName(location);
  const appKey = usePrompt(`App key [${defaultAppKey}]`, defaultAppKey);
  const githubOrganizationName = usePrompt(
    "Github organization [deegitalbe]",
    "deegitalbe"
  );
  const dockerhubOrganizationName = usePrompt(
    "Github organization [henrotaym]",
    "henrotaym"
  );

  const displayedData = {
    location,
    appKey,
    githubOrganizationName,
    dockerhubOrganizationName,
  };

  useDisplayJson(displayedData);

  const isConfirmed = useConfirm("Is it correct ? ");

  if (!isConfirmed) {
    useCancelSentence();
    useSentence("Come back when you're ready 😎");
    return;
  }

  const generator = useGenerator(displayedData);

  generator.copy(useStubsPath(), location);

  useSentence("Successfully scaffolded dockerization 🎉");
  useSentence("Next steps :");
  useSentence(
    "- Push you code and wait for github actions completion (Deploy could fail, it's expected). 🔧"
  );
  useSentence("- Make sure each migration contains a primary key. 🔧");
  useSentence(
    "- Install and publish horizon (https://laravel.com/docs/horizon#installation) 🔧"
  );
  useSentence(
    "- Add 'staging' key to you horizon.php config (copy 'production' key values) 🔧"
  );
  useSentence(
    "- Configure s3 filesystem (https://laravel.com/docs/filesystem#driver-prerequisites) 🔧"
  );
  useSentence(
    "- Install our flare package (https://github.com/henrotaym/laravel-flare-exception-handler/tree/3.x#readme) 🔧"
  );
  useSentence(`- ./cli root bootstrap && ./cli root start`);
  useSentence("You're good to go 🥳");
  useSentence(`Visit your app at https://${appKey}.docker.localhost`);
};

export default useScaffolding;
