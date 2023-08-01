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

  const isSailInstalled = useConfirm("Is laravel sail installed in the app ?");

  if (!isSailInstalled) {
    useCancelSentence();
    useSentence("Run 'composer require laravel/sail' first 🔧");
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

  const displayedData = {
    location,
    appKey,
    githubOrganizationName,
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
  useSentence("- Go to your app folder");
  useSentence("- npx @deegital/laravel-trustup-io-deployment@latest");
  useSentence("- Push code to github and wait for actions completion");
  useSentence("- Go to docker integration root folder");
  useSentence(
    `- ./cli bootstrap projects/${appKey} && ./cli start projects/${appKey}`
  );
  useSentence("You're good to go 🥳");
  useSentence(`Visit your app at https://${appKey}.docker.localhost`);
};

export default useScaffolding;
