import UnderlineLink from "@modules/common/components/underline-link"
import clsx from "clsx"
import Image from "next/image"
import { oddity } from "styles/fonts"

const Hero = () => {
  return (
    <div className="h-[90vh] w-full relative">
      <div className="text-white absolute inset-0 z-10 flex flex-col justify-center items-center text-center small:text-left small:justify-end small:items-start small:p-32">
        <h2 className={clsx("text-5xl font-semibold mb-4 drop-shadow shadow-black", oddity.className)}>
          Data-driven coffee roasting with full data transparency.
        </h2>
        <p className="text-base-regular max-w-[32rem] mb-6 drop-shadow shadow-black">
          Chaff Labs provides uniquely delicious coffee produced using custom-built merchandising automation and a connected roasting and packaging line.
        </p>
        <UnderlineLink href="/store">Explore coffees</UnderlineLink>
      </div>
      <Image
        src="/chaff_hero.jpg"
        loading="eager"
        priority={true}
        quality={90}
        alt="Coffee beans"
        className="absolute inset-0"
        draggable="false"
        fill
        sizes="100vw"
        style={{
          objectFit: "cover",
        }}
      />
    </div>
  )
}

export default Hero
